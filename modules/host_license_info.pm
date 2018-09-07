sub host_license_info
   {
   my $state = 2;
   my $output = 'Licence request error';
   my $service_content;
   my $host_license_manager;
   my $evaluation_period_expired = 0;
   my $evaluation_hours = 0;
   my $evaluation_minutes = 0;

   $service_content = Vim::get_service_content();

   if ($service_content->about->apiType eq 'HostAgent')
      {

      $host_license_manager = Vim::get_view( mo_ref => $service_content->licenseManager, properties => [ 'licenses', 'evaluation.properties' ]);

      if (@{$host_license_manager->licenses}[0]->name eq 'Evaluation Mode')
         {
         $output = "Host is in Evaluation Mode";
         $state = 1;
         foreach (@{$host_license_manager->get_property('evaluation.properties')})
           {
           if ($_->value eq 'Evaluation period has expired, please install license.')
              {
              $evaluation_period_expired = 1;
              }
           }
         if ($evaluation_period_expired)
            {
            $output .= " - Evaluation period has expired, please install license.";
            $state = 2;
            } else {
            foreach (@{$host_license_manager->get_property('evaluation.properties')})
               {
               if ( $_->key eq "expirationHours" )
                  {
                  $evaluation_hours = $_->value;
                  }
               if ( $_->key eq "expirationMinutes" )
                  {
                  $evaluation_minutes = $_->value;
                  }
               }
            if ($evaluation_hours <= 24)
               {
               $state = 2;
               }
            $output .= " - Evaluation Period Remaining: ";
            $output .= duration_exact($evaluation_hours * 60 * 60 + $evaluation_minutes * 60);
            }
      } else {
           $output = "Host is Licensed - Version: " . @{$host_license_manager->licenses}[0]->name;
           if (!defined($vmware_hidekey))
              {
              $output .= " - Key: " . @{$host_license_manager->licenses}[0]->licenseKey;
              }
           $state = 0;
      }
   }
   return ($state, $output);
   }

# A module always must end with a return code of 1. So placing 1 at the end of a module
# is a common method to ensure this.
1;
