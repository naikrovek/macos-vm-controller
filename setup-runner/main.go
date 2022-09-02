package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/helloyi/go-sshclient"
)

var (
	address = flag.String("ip", "", "tart VM IP to SSH into")
	token   = flag.String("token", "", "runner registration token")
	url     = flag.String("url", "", "API endpoint to register your runner")
)

func main() {
	flag.Parse()

	if *address == "" || *token == "" || *url == "" {
		os.Exit(1)
	}

	configureRunner(*address, *token, *url)
}

func configureRunner(ipaddress, registrationToken, url string) {
	// set up the ssh client
	client, err := sshclient.DialWithKey(ipaddress+":22", "admin", "tart.private.ssh.key")
	if err != nil {
		fmt.Println(err)
	}

	client.ScriptFile("/Users/admin/actions-runner/config.sh --url " + url + " --token " + registrationToken + " --unattended --ephemeral")

	err = client.Cmd("/Users/admin/actions-runner/run.sh").Run()
	if err != nil {
		fmt.Println(err)
	}

	err = client.Cmd("sudo shutdown -h now").Run()
	if err != nil {
		fmt.Println(err)
	}

	client.Close()
}
