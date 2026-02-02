local ImageFetcher = {
	FallbackMapping = {
		Logo = "rbxassetid://91685317120520",
	},
}

if not isfolder("Nova/Assets") then
	makefolder("Nova/Assets")
end

function SafeFetchCustomContentID(Path: string)
	local Success, Result = pcall(function()
		return getcustomasset(Path)
	end)

	return Success and Result or nil
end

function SafeFetchCustomImgData(url)
	local Success, Response = pcall(request, {
		Url = url,
		Method = "GET",
	})

	if Success and Response.Success or Response.StatusCode >= 200 and Response.StatusCode < 300 then
		return Response.Body
	end

	return nil
end

function ImageFetcher.GetRemoteImages(Images: { [string]: string })
	if not getcustomasset then
		return Images
	end

	local NewImages = {}
	for ClassName, Image in Images do
		if isfile(`Nova/Assets/{ClassName}.png`) then
			NewImages[ClassName] = SafeFetchCustomContentID(`Nova/Assets/{ClassName}.png`) or Image
			continue
		end

		local IconRawData = SafeFetchCustomImgData(`https://robloxapi.github.io/ref/icons/dark/{ClassName}.png`)
		if not IconRawData then
			NewImages[ClassName] = Image
			continue
		end

		writefile(
			`Nova/Assets/{ClassName}.png`,
			IconRawData
		)

		NewImages[ClassName] = SafeFetchCustomContentID(`Nova/Assets/{ClassName}.png`) or Image
	end

	return NewImages
end

function ImageFetcher.GetImage(Image: string)
	if not getcustomasset then
		return ImageFetcher.FallbackMapping[Image] or Image
	end

	if isfile(`Nova/Assets/{Image}.png`) then
		return SafeFetchCustomContentID(`Nova/Assets/{Image}.png`) or ImageFetcher.FallbackMapping[Image] or Image
	end

	local IconRawData = SafeFetchCustomImgData(`https://raw.githubusercontent.com/user/nova/refs/heads/main/Assets/{Image}.png`)

	if not IconRawData then
		return ImageFetcher.FallbackMapping[Image] or Image
	end

	writefile(`Nova/Assets/{Image}.png`, IconRawData)
	return SafeFetchCustomContentID(`Nova/Assets/{Image}.png`) or ImageFetcher.FallbackMapping[Image] or Image
end

return ImageFetcher
