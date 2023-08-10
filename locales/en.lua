local Translations = {
    success = {
        ApartmentDoorBusted = "You busted the door open",
    },
    error = {
        ApartmentDoorBusted = "Hey man, it's your neighbor. I heard a loud noise coming from your apartment. Is everything okay?",
        noapartmentfound = 'No apartment found',
        playernotonline = 'Player is not online',
        failed_createproperty = 'Failed to create property',
    },
    general = {
        accept = 'Accept',
        decline = 'Decline',
        openwardrobe = '[E] - Open Wardrobe',
        exit = '[E] - Exit',
        openstash = '[E] - Open Stash',
        stashname = 'Apartment Storage',
        logout = '[E] - Logout',
    },
    properties_menu = {
        garage = 'Garage',
        property = 'Property',
        showmenuhelp = '~g~E~w~ - Enter %{propertyType}',
    },
    create_property_menu = {
        title = 'Create Property',
    },
    apartment_menu = {
        title = 'Apartments',
        search_apartments = 'Search Apartments',
        enter_apartment = 'Enter Apartment',
    },
    apartments_menu = {
        input = {
            PlayerId = 'Player ID',
            PlayerName = 'Player Name',
            Search = 'Search',
            PlayerNameDefault = 'first and/or last name',
        },
        search_apartments = 'Search Apartments',
        ring_doorbell = 'Ring %{name}\'s doorbell',
        showmenuhelp = '[E] - See Apartments',
        doorbell_dialog = 'Someone is at the door',
        doorbell_dialog_content = '%{name} is at the door, do you want to let him in?',
        sidescroll = 'Enter %{name}\'s apartment',
        bust_door_open = 'Bust Door Open',
    },
    property_menu = {

    },
    manage_property_menu = {

    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})