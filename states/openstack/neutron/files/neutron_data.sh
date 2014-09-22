export OS_TENANT_NAME="admin"
export OS_USERNAME="admin"
export OS_PASSWORD="{{ADMIN_PASSWD}}"
export OS_AUTH_URL="http://{{CONTROL_IP}}:5000/v2.0/"

function get_id () {
    echo `"$@" | grep ' id ' | awk '{print $4}'`
}
		
NEUTRON_SERVICE=$(get_id \
keystone service-create --name=neutron \
                        --type=network \
                        --description="OpenStack Networking Service")

keystone endpoint-create --service-id="$NEUTRON_SERVICE" \
        --publicurl="http://{{CONTROL_IP}}:9696/" \
        --adminurl="http://{{CONTROL_IP}}:9696/" \
        --internalurl="http://{{CONTROL_IP}}:9696/"
