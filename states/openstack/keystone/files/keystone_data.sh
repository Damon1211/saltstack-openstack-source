export OS_SERVICE_TOKEN="{{ADMIN_TOKEN}}" 
export OS_SERVICE_ENDPOINT="http://{{CONTROL_IP}}:35357/v2.0"

function get_id () {
    echo `"$@" | grep ' id ' | awk '{print $4}'`
}

keystone user-create --name=admin --pass="{{ADMIN_PASSWD}}"
keystone tenant-create --name=admin --description="Admin Tenant"
keystone role-create --name=admin
keystone user-role-add --user=admin --tenant=admin --role=admin
keystone user-role-add --user=admin --role=_member_ --tenant=admin
					   
keystone tenant-create --name=demo
keystone user-create --name=demo --pass="{{USER_PASSWD}}"
keystone user-role-add --user=demo --role=_member_ --tenant=demo

KEYSTONE_SERVICE=$(get_id \
keystone service-create --name=keystone \
                        --type=identity \
                        --description="Keystone Identity Service")
						

keystone endpoint-create --service-id="$KEYSTONE_SERVICE" \
    --publicurl="http://{{CONTROL_IP}}:5000/v2.0" \
    --adminurl="http://{{CONTROL_IP}}:35357/v2.0" \
    --internalurl="http://{{CONTROL_IP}}:5000/v2.0"

keystone-manage pki_setup --keystone-user root --keystone-group root
chown -R root:root /etc/keystone/ssl
chmod -R o-rwx /etc/keystone/ssl
