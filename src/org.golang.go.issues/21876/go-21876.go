package main

import (
	"archive/tar"
	"archive/zip"
	"fmt"
	"io"
	"os"
)

func main() {
	_, err := TarTransform(os.Args[1], os.Args[2])
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Println("Everything is ok")
	}
}

func TarTransform(source string, destination string) (int64, error) {
	file, err := os.Open(source)
	if err != nil {
		return 0, err
	}

	err = file.Close()
	if err != nil {
		return 0, err
	}

	return transformZipToTar(source, destination)
}

func transformZipToTar(path, destPath string) (int64, error) {
	dest, err := os.OpenFile(destPath, os.O_WRONLY, 0666)
	if err != nil {
		return 0, err
	}
	defer dest.Close()

	zr, err := zip.OpenReader(path)
	if err != nil {
		fmt.Printf("1: err:%v\n", err)
		return 0, err
	}
	defer zr.Close()

	tarWriter := tar.NewWriter(dest)

	for _, zipEntry := range zr.File {
		err := writeZipEntryToTar(tarWriter, zipEntry)
		if err != nil {
			fmt.Printf("2: err:%v\n", err)
			return 0, err
		}
	}

	err = tarWriter.Close()
	if err != nil {
		fmt.Println("3: err:%v\n", err)
		return 0, err
	}

	fi, err := dest.Stat()
	if err != nil {
		fmt.Printf("3: err:%v\n", err)
		return 0, err
	}

	err = zr.Close()
	if err != nil {
		return 0, err
	}

	err = os.Remove(path)
	if err != nil {
		return 0, err
	}

	return fi.Size(), nil
}

func writeZipEntryToTar(tarWriter *tar.Writer, zipEntry *zip.File) error {
	zipInfo := zipEntry.FileInfo()
	return writeRegularZipEntryToTar(tarWriter, zipEntry, zipInfo)
}

func writeRegularZipEntryToTar(tarWriter *tar.Writer, zipEntry *zip.File, zipInfo os.FileInfo) error {
	tarHeader, err := tar.FileInfoHeader(zipInfo, "")
	if err != nil {
		fmt.Printf("4: err: %v\n", err)
		return err
	}

	// file info only populates the base name; we want the full path
	tarHeader.Name = zipEntry.FileHeader.Name

	zipReader, err := zipEntry.Open()
	if err != nil {
		fmt.Printf("5: err: %v\n", err)
		return err
	}

	defer zipReader.Close()

	err = tarWriter.WriteHeader(tarHeader)
	if err != nil {
		fmt.Printf("6: err: %v\n", err)
		return err
	}

	_, err = io.Copy(tarWriter, zipReader)
	if err != nil {
		fmt.Printf("7: err: %v\n", err)
		return err
	}

	err = tarWriter.Flush()
	if err != nil {
		fmt.Printf("8: err: %v\n", err)
		return err
	}

	return nil
}
