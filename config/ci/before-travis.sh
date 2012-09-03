# Start xvfb in preparation for selenium tests
sh -e /etc/init.d/xvfb start

# fetch extjs
wget http://cdn.sencha.io/ext-4.1.1-gpl.zip
unzip -q -d test/communitypack_test_app/public/ -n ext-4.1.1-gpl.zip
mv test/communitypack_test_app/public/extjs-4.1.1 test/communitypack_test_app/public/extjs

# cp db configuration
cp test/communitypack_test_app/config/database.yml.travis test/communitypack_test_app/config/database.yml

# create mysql database
mysql -e 'create database nct_test;'


cd test/communitypack_test_app
bundle install

bundle show

bundle exec rake db:migrate RAILS_ENV=test
cd ../..