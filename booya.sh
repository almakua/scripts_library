#!/bin/bash

DATABASE=mec2
EXCLUDED_TABLES=(
log_url_info
log_url
wgtntpro_consignmentno
log_visitor_info
sales_flat_shipment
report_viewed_product_index
report_event
log_visitor
sales_flat_quote_item_option
)

IGNORED_TABLES_STRING=''
for TABLE in "${EXCLUDED_TABLES[@]}"
do :
   IGNORED_TABLES_STRING+=" --ignore-table=${DATABASE}.${TABLE}"
done

echo $IGNORED_TABLES_STRING