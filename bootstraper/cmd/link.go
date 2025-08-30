/*
Copyright © 2025 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var linkCmd = &cobra.Command{
	Use:   "link",
	Short: "",
	Long:  "",
	Run: func(cmd *cobra.Command, args []string) {
		jsonFile, err := os.Open("../map.json")
		if err != nil {
			fmt.Printf("There was an error: %s", err)
		}

		var jsonData string

		jsonFile.Close()

		fmt.Println(jsonData)
	},
}

func init() {
	rootCmd.AddCommand(linkCmd)
}
