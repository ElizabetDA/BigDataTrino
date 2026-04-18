#!/bin/bash
set -e

mkdir -p /etc/clickhouse-server/users.d

cat > /etc/clickhouse-server/users.d/trino-user.xml <<'EOF'
<clickhouse>
    <users>
        <trino>
            <password>trino</password>
            <networks>
                <ip>::/0</ip>
            </networks>
            <profile>default</profile>
            <quota>default</quota>
            <access_management>1</access_management>
        </trino>
    </users>
</clickhouse>
EOF
