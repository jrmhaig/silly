#!/bin/bash

echo Enter root MySQL password
mysql -uroot -p < mytap/mytap.sql
