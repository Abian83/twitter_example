if Rails.env == "development"
	CLIENT_ID     = "3be91f77979d438886038bdf0aec18725508ba5493486c6b0cbcd7f92cd91372"
	CLIENT_SECRET = "3b0d221425033e2e9e70c042bf278f91c6169412518543ec83d7bfde35e821c7"
	REDIRECT_URI  = "http://localhost:3030/oauth/callback"
else
	CLIENT_ID     = "35ebb1495c2e5f0c5fc614f2adb6764ebd2c2cca853dc07b25b34f67f38e69c9"
	CLIENT_SECRET = "ff33e757473922906348783c169180b67fb45316e19a0880d457e15b86ddd22d"
	REDIRECT_URI  = "https://limitless-spire-2545.herokuapp.com/oauth/callback"	
end