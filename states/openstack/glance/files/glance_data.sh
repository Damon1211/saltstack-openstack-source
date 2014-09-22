export OS_TENANT_NAME="admin"
export OS_USERNAME="admin"
export OS_PASSWORD="{{ADMIN_PASSWD}}"
export OS_AUTH_URL="http://{{CONTROL_IP}}:5000/v2.0/"

function get_id () {
    echo `"$@" | grep ' id ' | awk '{print $4}'`
}
		
GLANCE_SERVICE=$(get_id \
keystone service-create --name=glance \
                        --type=image \
                        --description="OpenStack Image Service")

keystone endpoint-create --service-id="$GLANCE_SERVICE" \
        --publicurl="http://{{CONTROL_IP}}:9292" \
        --adminurl="http://{{CONTROL_IP}}:9292" \
        --internalurl="http://{{CONTROL_IP}}:9292"
