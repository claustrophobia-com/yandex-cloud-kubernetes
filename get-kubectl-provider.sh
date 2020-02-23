#!/usr/bin/env bash

download_links=`curl -sL https://api.github.com/repos/gavinbunney/terraform-provider-kubectl/releases/latest | jq -r '.assets[].browser_download_url'`

case "$OSTYPE" in
  darwin*)
  	download_link=`echo ${download_links} | tr ' ' '\n' | grep 'darwin'`
	OS="darwin"
  	ARCH="amd64"
  	;;
  linux*)
  	case "`uname -m`" in
	  x86_64)
	  	download_link=`echo ${download_links} | tr ' ' '\n' | grep 'linux-amd64'`
	  	OS="linux"
	  	ARCH="amd64"
	  	;;
	  i?86)
	  	download_link=`echo ${download_links} | tr ' ' '\n' | grep 'linux-386'`
	  	OS="linux"
	  	ARCH="386"
	  	;;
	  armv*)
	  	download_link=`echo ${download_links} | tr ' ' '\n' | grep 'linux-arm'`
	  	OS="linux"
	  	ARCH="arm"
	  	;;
	esac
  	;;
esac

plugins_path="terraform.d/plugins/${OS}_${ARCH}"

mkdir -p ${plugins_path}

curl -L# ${download_link} > ${plugins_path}/terraform-provider-kubectl

chmod +x ${plugins_path}/terraform-provider-kubectl
