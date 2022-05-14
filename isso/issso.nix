issoPackage = with pkgs.python3Packages; buildPythonPackage rec {
  pname = "isso";
  version = "custom";

  src = pkgs.fetchFromGitHub {
    # Use my fork
    owner = "vincentbernat";
    repo = pname;
    rev = "vbe/master";
    sha256 = "0vkkvjcvcjcdzdj73qig32hqgjly8n3ln2djzmhshc04i6g9z07j";
  };

  propagatedBuildInputs = [
    itsdangerous
    jinja2
    misaka
    html5lib
    werkzeug
    bleach
    flask-caching
  ];

  buildInputs = [
    cffi
  ];

  checkInputs = [ nose ];

  checkPhase = ''
    ${python.interpreter} setup.py nosetests
  '';
};