package cmd

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"

	"github.com/spf13/cobra"
)

type PackagesConfig map[string][]string

var installCmd = &cobra.Command{
	Use:   "install",
	Short: "",
	Long:  ``,
	Run: func(cmd *cobra.Command, args []string) {
		file, err := os.ReadFile("../packages.json")
		if err != nil {
			fmt.Printf("There was an error: %s", err)
			return
		}

		var config PackagesConfig
		jsonErr := json.Unmarshal(file, &config)
		if jsonErr != nil {
			return
		}

		for group, packages := range config {
			if group == "apt" {
				for _, packageName := range packages {
					output, cmdErr := exec.Command("sudo", "apt", "install", packageName, "-y").Output()
					if cmdErr != nil {
						fmt.Println("There was an error installing:", packageName)
						continue
					}

					fmt.Println(string(output))
				}
			}
		}
	},
}

func init() {
	rootCmd.AddCommand(installCmd)
}
