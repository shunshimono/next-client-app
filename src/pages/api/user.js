const mysql = require("promise-mysql");

export default async function handler(req, res) {
  try {
    const connection = await mysql.createPool({
      user: "shunshimono",
      password: "shun1019S",
      database: "guestbook",
      host: "127.0.0.1",
      port: "3306",
    });
    const result = await connection.query("SELECT * FROM entries;");
    res.status(200).json(result);
  } catch (err) {
    res
      .status(500)
      .send(
        "Unable to load page. Please check the application logs for more details."
      );
  }
}
