/*
Copyright © 2025 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

// installCmd represents the install command
var installCmd = &cobra.Command{
	Use:   "install",
	Short: "",
	Long:  ``,
	Run: func(cmd *cobra.Command, args []string) {
		packagesFile, err := os.Open("../packages.json")
		if err != nil {
			fmt.Printf("There was an error: %s", err)
		}
		defer packagesFile.Close()
	},
}

func init() {
	rootCmd.AddCommand(installCmd)
}
