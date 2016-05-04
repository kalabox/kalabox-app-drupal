#!/usr/bin/env bats

#
# Basic tests to verify drush things
#

# Load up environment
load env

#
# Setup some things
#
setup() {

  # Create a directory to put our test builds
  mkdir -p "$KBOX_APP_DIR"

  # We need to actually go into this app dir until
  # https://github.com/kalabox/kalabox/issues/1221
  # is resolved
  if [ -d "$KBOX_APP_DIR/$PHP_DRUPAL7_NAME" ]; then
    cd $KBOX_APP_DIR/$PHP_DRUPAL7_NAME
  fi

}

#
# Create a D7 Site for our purposes
#

# Create a drupal7 site
@test "Create a Drupal 7 site without an error." {

  # Check to see if our site exists already
  D7_SITE_EXISTS=$("$KBOX" list | grep "$PHP_DRUPAL7_NAME" > /dev/null && echo $? || true)

  # Run the create command if our site doesn't already exist
  if [ ! $D7_SITE_EXISTS ]; then

    # Create a drupal 7 site
    run $KBOX create drupal7 \
      -- \
      --name $PHP_DRUPAL7_NAME \
      --dir $KBOX_APP_DIR \
      --from $TRAVIS_BUILD_DIR/app

    # Check status code
    [ "$status" -eq 0 ]

  # We already have what we need so lets skip
  else
    skip "Looks like we already have a D7 site ready to go!"
  fi

}

#
# Do the site install
#
@test "Install our Drupal 7 site." {

  # Install a Drupal 7 site
  run $KBOX drush si --db-url=mysql://root@database/drupal -y
  [ "$status" -eq 0 ]
  [[ $output == *"Installation complete"* ]]

}

#
# Drush command checks
#

#
# Check that `drush up` works
# See: https://github.com/kalabox/kalabox/issues/1297
#
@test "Verify that drush up works" {

  # Disable and uninstall views if it exists
  $KBOX drush dis views -y
  $KBOX drush pmu views -y

  # Download an older version of views
  $KBOX drush dl views-7.x-3.0 -y

  # Enable views
  $KBOX drush en views -y

  # Attempt the update and check for an error
  run $KBOX drush up -y
  [ "$status" -eq 0 ]
  [[ $output != *"Unable to create"* ]]

}

#
# BURN IT TO THE GROUND!!!!
#
teardown() {
  sleep 1
}
