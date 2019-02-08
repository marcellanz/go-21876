
# Go Issue21876

https://github.com/golang/go/issues/21876

### introduction

[Issue21876](https://github.com/golang/go/issues/21876) states that _"archive/zip: Reader.Read returns ErrChecksum on certain files"_ where a zip file is created _"where the directory entries don't have the 'd' bit set"_. Further, then such a zip file is processed with some ruby code [2] where all directory entries in the zip file are removed. Last, Go is used to transforms the zip file to a tar file [1].

## what happened

IMO this is a non-issue from Go's point of view, here is why:

I was able to reproduce the issue on "go version go1.11.5 darwin/amd64" with the *.jar file and ruby code provided to this issue.

Also, I was able to create a similar zip file using _ZIP(1L)_ on MacOS that behaved similarly with the ruby script provided and then processed with the go code of this issue.

(I extracted both the go and ruby code here [\[0\]](https://github.com/marcellanz/go-21876) together with a test to reproduce the issue and a fix for it)

What seems to be happening is the following:
1. The given *.jar file contains _data descriptor entries_ [2] for each entry in the zip file.

1. The produced zip file by the ruby code [2] left bit 3 set on 1 of the _general purpose bit flag_ that is part of the _central directory header_ and that indicates the presence of a corresponding data descriptor entry for a file within the zip file…

1. … but Ruby's zip implementation _RubyZip_ [5] does not write data descriptor entries at all [6] (at least for all non-encryption zip files IMO / see ::Zip::NullDecrypter) and ignores the general purpose bit flag on bit 3 that was copied over initially [7].

1. Go's zip reader implementation reads the general purpose flag on bit 3 when reading the central directory header entry of every file in the zip file [8] and then expects to get to find a data descriptor entry after the corresponding file data section within the zip file.

1. Ultimately Go's zip reader reads a wrong CRC [9] since no data descriptor entry is present and then emits _ErrChecksum_

## test to reproduce

```
# see it fail
./run.sh
# see it not fail
./run.sh -fixed
```

## fix
To fix this issue on the issuers side, general purpose flags can be cleared.
```
e.gp_flags &= ~0x8
```

Also (I'm not a ruby expert) Rubyzip's zip output stream might have to be fixed for entries that where copied over from an existing zip file. There is an issue [10] on Rubyzip that is Open and indicates to be similar to Issue21876.
 
## ZIP data descriptor entries
missing data descriptor entries and leftover flags after Rubyzip modified zip file:
```
ZIP file structure (simplified)

      [local file header 1]
      [file data         1]
      [data descriptor   1] <- these are missing (incl. crc) after Rubyzip modified the zip file
      ...
      [local file header n]
      [file data         n]
      [data descriptor   n]
      ...
      [central directory header 1] <- bit 3 on the general purpose flags is still set
      ...
      [central directory header n]
```

## Refs

[0] https://github.com/marcellanz/go-21876

[1] https://github.com/marcellanz/go-21876/blob/master/src/org.golang.go.issues/21876/go-21876.go

[2] https://github.com/marcellanz/go-21876/blob/master/src/org.golang.go.issues/21876/go-21876-issue-script-given.rb

[3] https://github.com/marcellanz/go-21876/blob/master/src/org.golang.go.issues/21876/go-21876-issue-script-given-fixed.rb

[4] https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT

[5] https://github.com/rubyzip/rubyzip

[6] https://github.com/rubyzip/rubyzip/blob/master/lib/zip/output_stream.rb#L130-L131

[7] https://github.com/rubyzip/rubyzip/blob/master/lib/zip/central_directory.rb#L127

[8] https://github.com/golang/go/blob/release-branch.go1.11/src/archive/zip/reader.go#L170-L171

[9] https://github.com/golang/go/blob/release-branch.go1.11/src/archive/zip/reader.go#L447-L448

[10] https://github.com/rubyzip/rubyzip/issues/249