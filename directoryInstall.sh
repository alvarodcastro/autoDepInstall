#!/usr/bin/env zsh

if [[ $# -eq 1 ]];
then
  echo "Analyzing directory $1";
  cd $1 || { echo "Failed to change directory to $1"; exit 1; }
  mkdir -p ./.log
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
        base_path=$(find . -type f -name "setup.py" -o -name "pyproject.toml" -o -name "requirements.txt" -o -name "README.*" -o -name "LICENSE*" -o -name "setup.cfg" -o -type d -name "src" -o -type d -name "tests" -o -type d -name ".git" 2>/dev/null | sed -E 's|/[^/]+$||' | sort -u | head -n 1)

          # cd $1;

          echo "Trying to install ${package} at the following directory: ${base_path}";
          python -m build ${base_path} >./.log/${package}_install.log 2>./.log/${package}_error.log
          if [[ $? -eq 1 ]];
          then
              echo "[ERROR] trying to install ${package}, check de log at -> .log directory"
          fi
      done
    fi

	fi
else
    echo "Command usage with one arg";
fi
