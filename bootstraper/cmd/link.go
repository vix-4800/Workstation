/*
Copyright © 2025 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

type MapData map[string]map[string]string

var linkCmd = &cobra.Command{
	Use:   "link",
	Short: "",
	Long:  "",
	Run: func(cmd *cobra.Command, args []string) {
		mapFile, err := os.ReadFile("../map.json")
		if err != nil {
			fmt.Printf("There was an error: %s", err)
		}

		var mapData MapData
		unmarhalErr := json.Unmarshal(mapFile, &mapData)
		if unmarhalErr != nil {
			fmt.Printf("There was an error parsing json data: %s", unmarhalErr)
			panic(unmarhalErr)
		}

		for category, categoryItems := range mapData {
			for repoFilename, systemPath := range categoryItems {
				fmt.Printf("%s/%s -> %s\n", category, repoFilename, systemPath)
				// exec.Command("ln", "-sfn", repoFilename, systemPath)
			}
		}
	},
}

func init() {
	rootCmd.AddCommand(linkCmd)
}
