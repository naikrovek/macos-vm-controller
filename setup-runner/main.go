package main

import (
	"bytes"
	"flag"
	"fmt"
	"os"

	"github.com/helloyi/go-sshclient"
)

var (
	address = flag.String("ip", "", "tart VM IP to SSH into")
	token   = flag.String("token", "", "runner registration token")
	url     = flag.String("url", "", "API endpoint to register your runner")
	name    = flag.String("name", "", "the name/id of the runner")
)

func main() {
	flag.Parse()

	if *address == "" || *token == "" || *url == "" {
		os.Exit(1)
	}

	configureRunner(*address, *token, *url, *name)
}

// SSH into the MacOS VM, configure the GitHub Runner software, launch it, wait
// until it exits, shutdown the VM, and finally return.
func configureRunner(ipaddress, registrationToken, url, name string) {
	// set up the ssh client
	client, err := sshclient.DialWithKey(ipaddress+":22", "admin", "setup-runner/tart.private.ssh.key")
	printIf(err)
	defer client.Close()

	var stdout bytes.Buffer
	var stderr bytes.Buffer

	fmt.Println("Running:", "/Users/admin/actions-runner/config.sh --url "+url+" --token "+registrationToken+" --unattended --ephemeral --name "+name)
	err = client.Cmd("/Users/admin/actions-runner/config.sh --url "+url+" --token "+registrationToken+" --unattended --ephemeral --name "+name).SetStdio(&stdout, &stderr).Run()
	printIf(err)

	fmt.Println("stdout:")
	fmt.Println(stdout.String())

	fmt.Println()
	fmt.Println("stderr:")
	fmt.Println(stderr.String())

	stdout = *new(bytes.Buffer)
	stderr = *new(bytes.Buffer)

	fmt.Println("Running:", "/Users/admin/actions-runner/run.sh")
	err = client.Cmd("/Users/admin/actions-runner/run.sh").SetStdio(&stdout, &stderr).Run()
	printIf(err)

	fmt.Println("stdout:")
	fmt.Println(stdout.String())

	fmt.Println()
	fmt.Println("stderr:")
	fmt.Println(stderr.String())

	fmt.Println("Running:", "sudo shutdown -h now")
	err = client.Cmd("sudo shutdown -h now").Run()
	printIf(err)
}

func printIf(err error) {
	if err != nil {
		fmt.Println(err)
	}
}
