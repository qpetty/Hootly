require 'pushmeup'
APNS.host = 'gateway.push.apple.com'
APNS.pem = 'push_certs/ck.pem'
APNS.pass = 'Lorraine42'

#GCM.key = "AIzaSyANiPVXok3rf5HaGC507jLD_sDomQhdQhc"


#data = {:alert => 'hello from hootly'}
#response = GCM.send_notification("APA91bGgJ3dpuf6-oHYuWzV5n-3gX2bEAuyfULzSOWKk-F37vX49T4aQkhnCdgya1nFFxnY6RQcQXV0qsu9SpAsv66giw7xQlXjmmhcQ6t05NL87IOKGi_vlwC-VI1IN-0RUS8NNSYj_DgIF14sVhyYeDnEnWI1khw", data)

APNS.send_notification('48a666ab982446558a7720fb25e90a67952ae7a69037ed824979e6ef13dca0e5', :badge => 1, :alert => "first production notification", :sound => 'default')

