/*
Copyright © 2025 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"
	"os/exec"

	"github.com/spf13/cobra"
)

// updateCmd represents the update command
var updateCmd = &cobra.Command{
	Use:   "update",
	Short: "",
	Long:  ``,
	Run: func(cmd *cobra.Command, args []string) {
		output, err := exec.Command("git", "pull").Output()

		if err != nil {
			fmt.Printf("There was an error: %s", err)
		}

		fmt.Println(string(output))
	},
}

func init() {
	rootCmd.AddCommand(updateCmd)
}
