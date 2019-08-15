class Articles::Bloomberg
  def self.headers
    {
      'authority'                 => 'www.bloomberg.com',
      'pragma'                    => 'no-cache',
      'cache-control'             => 'no-cache',
      'upgrade-insecure-requests' => '1',
      'sec-fetch-mode'            => 'navigate',
      'sec-fetch-user'            => '?1',
      'accept'                    => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3',
      'sec-fetch-site'            => 'none',
      'accept-encoding'           => 'gzip, deflate, br',
      'accept-language'           => 'en-US,en;q=0.9,ru;q=0.8,be;q=0.7'
    }
  end
end
