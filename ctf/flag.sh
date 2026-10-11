#!/bin/sh
# Places each player's flag (CTF_FLAG_<KEY>, given by the launcher) in the crAPI data that the
# matching challenge exposes; without one (CI, a run by hand) the development flag. Runs in the
# workshop image (Python with psycopg2 and pymongo) once the workshop has seeded its data, and
# rewrites the same rows on every start.
exec python3 - <<'PY'
import os, re, time
import psycopg2, pymongo

def flag(key):
    dev = "FLAG{dev-crapi-%s}" % key.lower().replace("_", "-")
    return os.environ.get("CTF_FLAG_" + key) or dev

MAIN = flag("MAIN")
VEHICLE = flag("VEHICLE_LOCATION")
REPORT = flag("MECHANIC_REPORT")
RESET = flag("PASSWORD_RESET")
NOSQL = flag("NOSQL_COUPON")
SQL = flag("SQL_COUPON")
ORDER = flag("UNAUTH_ORDER")

def pg():
    for _ in range(120):
        try:
            return psycopg2.connect(host=os.environ["DB_HOST"], port=os.environ["DB_PORT"],
                                    dbname=os.environ["DB_NAME"], user=os.environ["DB_USER"],
                                    password=os.environ["DB_PASSWORD"])
        except Exception:
            time.sleep(2)
    raise SystemExit("postgres unreachable")

def wait_rows(cur, sql, n):
    for _ in range(120):
        cur.execute(sql)
        if cur.fetchone()[0] >= n:
            return
        time.sleep(2)
    raise SystemExit("seed data missing: " + sql)

conn = pg()
conn.autocommit = True
cur = conn.cursor()
wait_rows(cur, "SELECT count(*) FROM service_request", 5)
wait_rows(cur, 'SELECT count(*) FROM "order"', 5)

# Challenge 1 (BOLA): the location of the vehicles of the users who wrote the seeded posts.
cur.execute("""UPDATE vehicle_location SET latitude = %s WHERE id IN (
  SELECT d.location_id FROM vehicle_details d JOIN user_login u ON u.id = d.owner_id
  WHERE u.email IN ('adam007@example.com', 'pogba006@example.com', 'robot001@example.com'))""",
            (VEHICLE,))

# Challenge 2 (BOLA): a reference line in the seeded mechanic reports of other users.
cur.execute("SELECT id, problem_details FROM service_request ORDER BY id LIMIT 5")
for rid, text in cur.fetchall():
    text = re.sub(r"\nService ref: .*$", "", text or "", flags=re.S).rstrip("\n")
    cur.execute("UPDATE service_request SET problem_details = %s WHERE id = %s",
                (text + "\nService ref: " + REPORT, rid))

# Challenge 13 (SQL injection): a table of its own in the crapi database.
cur.execute("CREATE TABLE IF NOT EXISTS flags (flag varchar(255) NOT NULL)")
cur.execute("DELETE FROM flags")
cur.execute("INSERT INTO flags (flag) VALUES (%s)", (SQL,))

# Challenge 14 (unauthenticated access): the transaction id of the seeded orders.
cur.execute('UPDATE "order" SET transaction_id = %s WHERE id IN '
            '(SELECT id FROM "order" ORDER BY id LIMIT 5)', (ORDER,))

# Challenges 3 (password reset) and 15 (JWT forgery, main): the name of a profile video that
# only the account owner's dashboard shows.
cur.execute("""SELECT data_type FROM information_schema.columns
               WHERE table_name = 'profile_video' AND column_name = 'video'""")
row = cur.fetchone()
blob = "lo_from_bytea(0, %s)" if row and row[0] == "oid" else "%s"
for vid, email, value in ((1000001, "admin@example.com", MAIN),
                          (1000002, "robot001@example.com", RESET)):
    cur.execute("SELECT id FROM user_login WHERE email = %s", (email,))
    uid = cur.fetchone()[0]
    cur.execute("SELECT id FROM profile_video WHERE user_id = %s", (uid,))
    if cur.fetchone():
        cur.execute("UPDATE profile_video SET video_name = %s WHERE user_id = %s", (value, uid))
    else:
        cur.execute("INSERT INTO profile_video (id, video_name, conversion_params, video, user_id) "
                    "VALUES (%s, %s, %s, " + blob + ", %s)",
                    (vid, value, "-v codec h264", psycopg2.Binary(b"\x00"), uid))

# Challenge 12 (NoSQL injection): the code of the first coupon the community service returns.
mongo = pymongo.MongoClient(host=os.environ["MONGO_DB_HOST"], port=int(os.environ["MONGO_DB_PORT"]),
                            username=os.environ["MONGO_DB_USER"],
                            password=os.environ["MONGO_DB_PASSWORD"])
coupons = mongo[os.environ["MONGO_DB_NAME"]]["coupons"]
for _ in range(120):
    first = coupons.find_one({})
    if first:
        break
    time.sleep(2)
else:
    raise SystemExit("no coupons seeded")
coupons.update_one({"_id": first["_id"]}, {"$set": {"coupon_code": NOSQL}})
print("crAPI flags placed")
PY
