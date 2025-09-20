email_from="trevor.j.little@gmail.com"; export email_from
email_to="trevor.j.little@gmail.com"; export email_to
email_cc="trevor.j.little@gmail.com"; export email_cc
email_subject="$(echo -e "CRITICAL: Bad Data\nX-Priority: 1\nX_Message_flag: Follow up")"; export email_subject
email_body="This is to notify user of bad data \n\n this is an automated alert.\n\n Thanks. \n\n Production Support Team"; export email_body
email_attachment="/path/to/some/file"; export email_attachment
