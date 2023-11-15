#!/bin/bash

RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
PUR='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

echo -e "${CYAN}*-------------------*---------------------*${NC}"
echo -e "${YEL}* Check MDM - Skip MDM Auto for MacOS by *${NC}"
echo -e "${RED}*             SKIPMDM.COM                *${NC}"
echo -e "${RED}*            Phoenix Team                *${NC}"
echo -e "${CYAN}*-------------------*---------------------*${NC}"
echo ""

PS3='Please enter your choice: '
options=("Autoypass on Recovery" "Reboot")

select opt in "${options[@]}"; do
	case $opt in
	"Autoypass on Recovery")
		echo -e "${GRN}Bypass on Recovery"

		# Prepare Volumes
		systemVolumePath="/Volumes/Macintosh HD"
		dataVolumePath="/Volumes/Macintosh HD - Data"
		if [ -d "$dataVolumePath" ]; then
			diskutil rename "Macintosh HD - Data" "Data"
		fi

		# Create user
		dscl_path='/Volumes/Data/private/var/db/dslocal/nodes/Default'
		localUserDirPath="/Local/Default/Users"
		defaultUID="501"
		echo -e "${GRN}Create a new user / Tạo User mới"
		echo -e "${BLU}Press Enter to continue, Note: Leaving it blank will default to the automatic user / Nhấn Enter để tiếp tục, Lưu ý: có thể không điền sẽ tự động nhận User mặc định"
		echo -e "Enter the username (Default: Apple) / Nhập tên User (Mặc định: Apple)"
		read -rp "Full name: " fullName
		fullName="${fullName:=Apple}"

		echo -e "${BLUE}Nhận username ${RED}WRITE WITHOUT SPACES / VIẾT LIỀN KHÔNG DẤU ${GRN} (Mặc định: Apple)"
		read -rp "Username: " username
		username="${username:=Apple}"

		echo -e "${BLUE}Enter the password (default: 1234) / Nhập mật khẩu (mặc định: 1234)"
		read -rsp "Password: " userPassword
		userPassword="${userPassword:=1234}"

		echo -e "${GREEN}Creating User / Đang tạo User"
		dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username"
		dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" UserShell "/bin/zsh"
		dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" RealName "$fullName"
		dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" UniqueID "$defaultUID"
		dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" PrimaryGroupID "20"
		mkdir "$dataVolumePath/Users/$username"
		dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" NFSHomeDirectory "/Users/$username"
		dscl -f "$dscl_path" localhost -passwd "$localUserDirPath/$username" "$userPassword"
		dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"

		# Block MDM hosts
		hostsPath="$systemVolumePath/etc/hosts"
		echo "0.0.0.0 deviceenrollment.apple.com" >>"$hostsPath"
		echo "0.0.0.0 mdmenrollment.apple.com" >>"$hostsPath"
		echo "0.0.0.0 iprofiles.apple.com" >>"$hostsPath"
		echo -e "${GREEN}Successfully blocked host / Thành công chặn host${NC}"

		# Remove config profile
		configProfilesSettingsPath="$systemVolumePath/var/db/ConfigurationProfiles/Settings"
		touch "$dataVolumePath/private/var/db/.AppleSetupDone"
		rm -rf "$configProfilesSettingsPath/.cloudConfigHasActivationRecord"
		rm -rf "$configProfilesSettingsPath/.cloudConfigRecordFound"
		touch "$configProfilesSettingsPath/.cloudConfigProfileInstalled"
		touch "$configProfilesSettingsPath/.cloudConfigRecordNotFound"

		echo -e "${CYAN}------ Autobypass SUCCESSFULLY / Autobypass HOÀN TẤT ------${NC}"
		echo -e "${CYAN}------ Exit Terminal , Reset Macbook and ENJOY ! ------${NC}"
		break
		;;

	"Check MDM Enrollment")
		echo ""
		echo -e "${GRN}Check MDM Enrollment. Error is success${NC}"
		echo ""
		echo -e "${RED}Please Insert Your Password To Proceed${NC}"
		echo ""
		sudo profiles show -type enrollment
		break
		;;

	"Exit")
		echo "Rebooting..."
		reboot
		break
		;;

	*)
		echo "Invalid option $REPLY"
		;;
	esac
done
