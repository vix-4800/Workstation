package main

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"gopkg.in/yaml.v3"
)

type Config struct {
	Development  map[string]string `yaml:"development"`
	Shell        map[string]string `yaml:"shell"`
	Desktop      map[string]string `yaml:"desktop"`
	Applications map[string]string `yaml:"applications"`
}

// ParseYAMLConfig parses the YAML configuration file and returns a flat map
func ParseYAMLConfig(configPath string) (map[string]string, error) {
	data, err := os.ReadFile(configPath)
	if err != nil {
		return nil, err
	}

	var config Config
	if err := yaml.Unmarshal(data, &config); err != nil {
		return nil, err
	}

	// Flatten the config into a single map
	result := make(map[string]string)

	for k, v := range config.Development {
		result[k] = v
	}
	for k, v := range config.Shell {
		result[k] = v
	}
	for k, v := range config.Desktop {
		result[k] = v
	}
	for k, v := range config.Applications {
		result[k] = v
	}

	return result, nil
}

// ParseLegacyConfig parses the old tab-separated format
func ParseLegacyConfig(configPath string) (map[string]string, error) {
	file, err := os.Open(configPath)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	result := make(map[string]string)
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		parts := strings.Split(line, "\t")
		if len(parts) >= 2 {
			source := strings.TrimSpace(parts[0])
			target := strings.TrimSpace(parts[1])
			result[source] = target
		}
	}

	return result, scanner.Err()
}

// GenerateConfmap generates the old format from YAML for backward compatibility
func GenerateConfmap(yamlPath, outputPath string) error {
	config, err := ParseYAMLConfig(yamlPath)
	if err != nil {
		return err
	}

	file, err := os.Create(outputPath)
	if err != nil {
		return err
	}
	defer file.Close()

	// Write header
	fmt.Fprintln(file, "# Generated from dotfiles.yaml - do not edit manually")
	fmt.Fprintln(file, "# Edit dotfiles.yaml instead and run: go run . generate")
	fmt.Fprintln(file)

	// Collect and sort mappings for consistent output
	type mapping struct {
		source, target string
	}
	var mappings []mapping

	for source, target := range config {
		// Expand $HOME in target path
		expandedTarget := strings.ReplaceAll(target, "~", "$HOME")
		mappings = append(mappings, mapping{source, expandedTarget})
	}

	// Sort by source path for consistent output
	sort.Slice(mappings, func(i, j int) bool {
		return mappings[i].source < mappings[j].source
	})

	// Write mappings
	for _, m := range mappings {
		fmt.Fprintf(file, "%s\t%s\n", m.source, m.target)
	}

	return nil
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run . [generate|parse|help]")
		return
	}

	command := os.Args[1]

	switch command {
	case "generate":
		repoRoot := "../.."
		yamlPath := filepath.Join(repoRoot, "dotfiles.yaml")
		outputPath := filepath.Join(repoRoot, "linux.confmap")

		if err := GenerateConfmap(yamlPath, outputPath); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
		fmt.Println("Generated linux.confmap from dotfiles.yaml")

	case "parse":
		yamlPath := "../../dotfiles.yaml"
		config, err := ParseYAMLConfig(yamlPath)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error parsing YAML: %v\n", err)
			os.Exit(1)
		}

		fmt.Println("Parsed configuration:")
		for source, target := range config {
			fmt.Printf("  %s -> %s\n", source, target)
		}

	case "help":
		fmt.Println("Dotfiles Configuration Manager")
		fmt.Println()
		fmt.Println("Commands:")
		fmt.Println("  generate  Generate linux.confmap from dotfiles.yaml")
		fmt.Println("  parse     Parse and display dotfiles.yaml content")
		fmt.Println("  help      Show this help message")

	default:
		fmt.Printf("Unknown command: %s\n", command)
		fmt.Println("Run 'go run . help' for available commands")
		os.Exit(1)
	}
}
