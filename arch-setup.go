package main

import (
	"fmt"
	"os/exec"
	"strings"
)

func main() {
	updateSystem()
}

func updateSystem() {
	fmt.Println("Updating...")
	installPackages([]string{"cpu-microcode", "intel"})
}

func updateMirrorList() {}

func installPackages(packages []string) {
	fmt.Print(strings.Join(packages, " "))

	cmd := exec.Command(strings.Join(packages, " "))
	if err := cmd.Run(); err != nil {
		fmt.Println("Something went wrong")
	}
}
