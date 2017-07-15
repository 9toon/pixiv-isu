@dir = "/home/isucon/private_isu/webapp/ruby/"
working_directory @dir

worker_processes 1
preload_app true

listen "/dev/shm/app.sock"
