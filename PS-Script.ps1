<# Get US Page1 Results#>
function Get-Movies {
    [CmdletBinding()]
    param (
        
        $array = @()
    )
    
    process {
        try {
            $APIKey = 'APIkey'
            $Movies1 = (Invoke-RestMethod -Method Get -Uri "https://api.themoviedb.org/3/movie/top_rated?api_key=$($APIKey)&language=en-US&page=1").results
            $Movies2 = (Invoke-RestMethod -Method Get -Uri "https://api.themoviedb.org/3/movie/top_rated?api_key=$($APIKey)&language=en-US&page=2").results
            $Movies3 = (Invoke-RestMethod -Method Get -Uri "https://api.themoviedb.org/3/movie/top_rated?api_key=$($APIKey)&language=en-US&page=3").results
            $array += $Movies1
            $array += $Movies2
            $array += $Movies3

            return $array
            
        }
        catch [System.Net.WebException],[System.IO.IOException] {
            "Unable to get popular from https://api.themoviedb.org."
        }
    }
    end {
        Write-Host "Total Movie Count is" $array.Count
    }
}

<# Get Popular #>
function Get-Popular {
    [CmdletBinding()]
    param (

    )
    
    process {
        try {
            $APIKey = 'APIkey'
            $TopRatedMovies = (Invoke-RestMethod -Method Get -Uri "https://api.themoviedb.org/3/movie/popular?api_key=$($APIKey)&language=en-US&page=1").results
            $TopRatedMovies  
        }
        catch [System.Net.WebException],[System.IO.IOException] {
            "Unable to get popular from https://api.themoviedb.org."
        }
    } 

    end {
        Write-Host "Total Movie Count is" $TopRatedMovies.Count
    }
}

<# Set movie nfo file #>
function Set-File {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        $APIKey = 'APIkey'
        $TopRatedMovies = (Invoke-RestMethod -Method Get -Uri "https://api.themoviedb.org/3/movie/popular?api_key=$($APIKey)&language=en-US").results
        

        $XMLSettings = New-Object System.Xml.XmlWriterSettings
        $XMLSettings.Indent = $true
        $XMLSettings.IndentChars = "  "
    }
    
    process {
        foreach ($Movie in $TopRatedMovies) {

            $FileName = $Movie.title
         
            [System.IO.Path]::GetInvalidFileNameChars() | ForEach-Object {$FileName = $FileName.replace($_, '.')}

            New-Item -Path "C:\Users\alpin\Ps-Script\Movies\" -Name "$Filename" -ItemType "directory"
            New-Item -Path "C:\Users\alpin\Ps-Script\Movies\$($FileName)" -Name "$($Filename).mp4" -ItemType "file"
            $FilePath = "C:\Users\alpin\Ps-Script\Movies\$($FileName)\$($FileName).nfo"
        
            $XMLWriter = [System.Xml.XmlWriter]::Create($FilePath,$XMLSettings)
            $XMLWriter.WriteStartDocument()
            $XMLWriter.WriteStartElement("movie")
        
            $XMLWriter.WriteElementString("title","$($Movie.title)")  

            $XMLWriter.WriteStartElement("uniqueid")
            $XMLWriter.WriteAttributeString("type","tmdb")
            $XMLWriter.WriteAttributeString("default","true")
            $XMLWriter.WriteString("$($movie.id)")
            $XMLWriter.WriteEndElement()
            
            $XMLWriter.WriteStartElement("plot")
            $XMLWriter.WriteString("$($movie.overview)")
            $XMLWriter.WriteEndElement()
            
            $XMLWriter.WriteStartElement("thumb")
            $XMLWriter.WriteAttributeString("aspect", "poster")
            $XMLWriter.WriteAttributeString("preview", "")
            $XMLWriter.WriteString("https://image.tmdb.org/t/p/original$($Movie.poster_path)")
            $XMLWriter.WriteEndElement()

            $XMLWriter.WriteStartElement("fanart")
            $XMLWriter.WriteStartElement("thumb")
            $XMLWriter.WriteAttributeString("aspect", "landscape")
            $XMLWriter.WriteAttributeString("preview", "")
            $XMLWriter.WriteString("https://image.tmdb.org/t/p/original$($Movie.backdrop_path)")
            $XMLWriter.WriteEndElement()
            $XMLWriter.WriteEndElement()

            $MovieDetails = (Invoke-RestMethod -Method Get -Uri "https://api.themoviedb.org/3/movie/$($movie.id)?api_key=$($APIKey)&language=en-US&append_to_response=credits")

            foreach($cast in $MovieDetails.credits.cast) {
                $XMLWriter.WriteStartElement("actor")
                $XMLWriter.WriteElementString("name", $cast.name)
                $XMLWriter.WriteElementString("role", $cast.character)
                $XMLWriter.WriteElementString("order", $cast.order)
                $XMLWriter.WriteElementString("thumb", "https://image.tmdb.org/t/p/original$($cast.profile_path)")
                $XMLWriter.WriteEndElement()
            }

            foreach ($Genre in $MovieDetails.genres) {
                $XMLWriter.WriteElementString("genre", $Genre.name)
            }

            foreach ($Country in $MovieDetails.production_countries) {
                $XMLWriter.WriteElementString("country", $Country.name)
            }
            foreach ($Company in $MovieDetails.production_companies) {
                $XMLWriter.WriteElementString("studio", $Company.name)
            }
            
            $XMLWriter.WriteStartElement("premiered")
            $XMLWriter.WriteString("$($Movie.release_date)")
            $XMLWriter.WriteEndElement()
            
            $XMLWriter.WriteStartElement("ratings")
            $XMLWriter.WriteStartElement("rating")
            $XMLWriter.WriteAttributeString("name","themoviedb")
            $XMLWriter.WriteAttributeString("max",10)
            
            $XMLWriter.WriteElementString("value", $Movie.vote_average)
            $XMLWriter.WriteElementString("votes", $Movie.vote_count)
        
            $XMLWriter.WriteEndElement()
            $XMLWriter.WriteEndElement()
        
            $XMLWriter.WriteEndElement()
            $XMLWriter.WriteEndDocument()
            $XMLWriter.Flush()
            $XMLWriter.Close()  
        }
    }
}

function Get-UpcommingMovies {
    [CmdletBinding()]
    param (
        
    )
    
    process {
        try {
            $APIKey = 'APIkey'
            $UpcommingMovies= (Invoke-RestMethod -Method Get -Uri "https://api.themoviedb.org/3/movie/upcoming?api_key=$($APIKey)&language=en-US&page=1&append_to_response=credits").results
            $UpcommingMovies
        }
        catch {
            "error getting upcomming movies"
            
        }

    } 

    end {
        $UpcommingMovies.Count
    }
}

$array = get-movies