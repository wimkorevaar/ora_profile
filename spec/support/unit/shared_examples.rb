RSpec.shared_examples "NOT stopping listener" do |home, listener|
  it { is_expected.not_to contain_db_listener("Stop listener #{listener} from home #{home}")}
end

RSpec.shared_examples "NOT stopping OCM" do
  it { is_expected.not_to contain_exec('stop OCM for patching on /home1')}
end

RSpec.shared_examples "NOT stopping Oracle on home" do |home, database|
  it { is_expected.not_to contain_db_control("database stop #{database}")}
end

RSpec.shared_examples "stopping listener" do |home, listener|
  it { is_expected.to contain_db_listener("Stop listener #{listener} from home #{home}")
    .with('ensure'          => 'stop')
    .with('listener_name'   => "#{listener}")
    .with('oracle_home_dir' => "#{home}")
    .with('os_user'         => 'oracle')
    .with('schedule'        => 'db_patchschedule')
  }
end

RSpec.shared_examples "stopping OCM" do
  it { is_expected.to contain_exec('stop OCM for patching on /home1')
    .with('command'  => '/bin/systemctl stop ocm')
    .with('onlyif'   => '/bin/test -e /etc/rc.d/init.d/ocm')
    .with('schedule' => 'db_patchschedule')
  }
end

RSpec.shared_examples "stopping Oracle on home" do |home, database|
  it { is_expected.to contain_db_control("database stop #{database}")
    .with('ensure'                  => 'stop')
    .with('instance_name'           => database)
    .with('oracle_product_home_dir' => home)
    .with('os_user'                 => 'oracle')
    .with('provider'                => 'sqlplus')
    .with('schedule'                => 'db_patchschedule')
  }
end

RSpec.shared_examples "NOT starting listener" do |home, listener|
  it { is_expected.not_to contain_db_listener("Start listener #{listener} from home #{home}")}
end

RSpec.shared_examples "NOT starting OCM" do
  it { is_expected.not_to contain_exec('Starting OCM after applying DB patches on /home1')}
end

RSpec.shared_examples "NOT starting Oracle on home" do |home, database|
  it { is_expected.not_to contain_db_control("database start #{database}")}
end

RSpec.shared_examples "starting listener" do |home, listener|
  it { is_expected.to contain_db_listener("Start listener #{listener} from home #{home}")
    .with('ensure'          => 'start')
    .with('listener_name'   => "#{listener}")
    .with('oracle_home_dir' => "#{home}")
    .with('os_user'         => 'oracle')
    .with('schedule'        => 'db_patchschedule')
  }
end

RSpec.shared_examples "starting OCM" do
  it { is_expected.to contain_exec('Starting OCM after applying DB patches on /home1')
    .with('command'  => '/bin/systemctl start ocm')
    .with('onlyif'   => '/bin/test -e /etc/rc.d/init.d/ocm')
    .with('schedule' => 'db_patchschedule')
  }
end

RSpec.shared_examples "starting Oracle on home" do |home, database|
  it { is_expected.to contain_db_control("database start #{database}")
    .with('ensure'                  => 'start')
    .with('instance_name'           => database)
    .with('oracle_product_home_dir' => home)
    .with('os_user'                 => 'oracle')
    .with('provider'                => 'sqlplus')
    .with('schedule'                => 'db_patchschedule')
  }
end

RSpec.shared_examples "NOT updating Oracle on home" do |home, database|
  it { is_expected.not_to contain_exec("Datapatch for #{database}")}
  it { is_expected.not_to contain_exec("SQLPlus UTLRP #{database}")}
end

RSpec.shared_examples "updating Oracle on home" do |home, database|
  it { is_expected.to contain_exec("Datapatch for #{database}")
    .with('command'     => "/bin/sh -c 'unset ORACLE_PATH SQLPATH TWO_TASK TNS_ADMIN; #{home}/OPatch/datapatch -verbose'")
    .with('cwd'         => "#{home}/OPatch")
    .with('environment' => "[\"PATH=/usr/bin:/bin:#{home}/bin\", \"ORACLE_SID=#{database}\", \"ORACLE_HOME=#{home}\"]")
    .with('user'        => 'oracle')
    .with('logoutput'   => 'on_failure')
    .with('timeout'     => '3600')
    .with('schedule'    => 'db_schedule')
    .that_comes_before("Exec[SQLPlus UTLRP #{database}]")
  }

  it { is_expected.to contain_exec("SQLPlus UTLRP #{database}")
    .with('command'     => "/bin/sh -c 'unset TWO_TASK TNS_ADMIN; #{home}/bin/sqlplus / as sysdba @?/rdbms/admin/utlrp'")
    .with('cwd'         => home,)
    .with('environment' => "[\"PATH=/usr/bin:/bin:#{home}/bin\", \"ORACLE_SID=#{database}\", \"ORACLE_HOME=#{home}\"]")
    .with('user'        => 'oracle')
    .with('logoutput'   => 'on_failure')
    .with('timeout'     => '3600')
    .with('schedule'    => 'db_schedule')
  }
end
