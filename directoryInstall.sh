#!/usr/bin/env zsh

if [[ $# -eq 1 ]];
then
  echo "Analyzing directory $1";
  cd $1 || { echo "Failed to change directory to $1"; exit 1; }
  directoryList=()
  if [[ $? -eq 0 ]];
  then
        
    for file in $(ls)
    do
	    echo "The file: $file";
	    name_without_extension=$(basename "$file" | sed 's/\(.*\)\..*/\1/' | sed 's/\(.*\)\..*/\1/') 
	    echo "Without $name_without_extension"
	    extension=$(echo "$file" | sed "s/$name_without_extension//")
	    echo "The extension is $extension"
	    if [[ "${extension}" =  ".tar.gz" ]]; then
        echo "Extracting file $file";

        mkdir $name_without_extension;
        if [[ $? -eq 0 ]];
        then
            tar -xzvf $file -C $name_without_extension;
            echo "Content extracted to ${name_without_extension}";
            directoryList+=("$name_without_extension");
        fi

      else
        echo "The file should be .tar.gz";
      fi
    done

    # Proceed with the installation
    if [[ ${#directoryList} -ne 0  ]];
    then
      echo "Number of files extracted: ${#directoryList}";
      installFile="setup.py";
      for package in $directoryList:
      do
        installationDir=$(find ${package} -name "src")
          # cd $1;

          echo "Trying to install ${package}";
          python -m build ${installationDir}

      done
    fi

	fi
else
    echo "Command usage with one arg";
fi
