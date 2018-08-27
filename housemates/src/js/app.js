App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    // Load pets.
    $.getJSON('../houses.json', function(data) {
      var houseRow = $('#houseRow');
      var houseTemplate = $('#houseTemplate');

      for (i = 0; i < data.length; i ++) {
        houseTemplate.find('.panel-title').text(data[i].name);
        houseTemplate.find('img').attr('src', data[i].picture);
        houseTemplate.find('.pet-breed').text(data[i].breed);
        houseTemplate.find('.house-rooms').text(data[i].rooms);
        houseTemplate.find('.house-location').text(data[i].location);
        houseTemplate.find('.btn-housemate').attr('data-id', data[i].id);

        houseRow.append(houseTemplate.html());
      }
    });

    return App.initWeb3();
  },

  initWeb3: function() {
    // Is there an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fall back to Ganache
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('House.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var HouseArtifact = data;
      // Truffle contract is redundant to web3, but allows you to absorb truffle build files
      // with deployed addresses and ABIs that you  would have to set otherwise in Web3 - NJ
      App.contracts.House = TruffleContract(HouseArtifact);

      // Set the provider for our contract
      App.contracts.House.setProvider(App.web3Provider);

      // Use our contract to retrieve and mark the adopted pets
      return App.isHousemates();
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-housemate', App.handleAddHousemate);
  },

  bindEvents: function() {
    $(document).on('click', '.btn-house', App.handleNewHouse);
  },

  markAdded: function(adopters, account) {
    var houseInstance;

    App.contracts.House.deployed().then(function(instance) {
      houseInstance = instance;

      return houseInstance.getAdopters.call();
    }).then(function(adopters) {
      for (i = 0; i < adopters.length; i++) {
        if (adopters[i] !== '0x0000000000000000000000000000000000000000') {
          $('.panel-house').eq(i).find('button').text('Success').attr('disabled', true);
        }
      }
    }).catch(function(err) {
      console.log(err.message);
    });
  },

  handleAddNewHouse: function(event) {
    event.preventDefault();
    var houseName = "Stanley St";
    var houseInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.HouseFactory.deployed().then(function(instance) {
        houseInstance = instance;

        // Execute adopt as a transaction by sending account
        return houseInstance.addHousemate(houseId, {from: account});
      }).then(function(result) {
        return App.markAdded();
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },


  handleAddHousemate: function(event) {
    event.preventDefault();

    var houseId = parseInt($(event.target).data('id'));
    var houseInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.HouseFactory.deployed().then(function(instance) {
        houseInstance = instance;

        // Execute adopt as a transaction by sending account
        return houseInstance.addHousemate(houseId, {from: account});
      }).then(function(result) {
        return App.markAdded();
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
