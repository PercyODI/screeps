/*
 * Module code goes here. Use 'module.exports' to export things:
 * module.exports = 'a thing';
 *
 * You can import it from another modules like this:
 * var mod = require('builder'); // -> 'a thing'
 */
var _ = require('lodash');
var harvester = require("harvester");
  
module.exports = function(creep) {
    var spawn = Game.spawns.Spawn1;
    var construtionSites = creep.room.find(FIND_CONSTRUCTION_SITES);
    var defences = creep.room.find(FIND_STRUCTURES, {
        filter: function(structure) {
            return structure.structureType == STRUCTURE_WALL || structure.structureType == STRUCTURE_RAMPART;
        }
    })
    defences = _.sortBy(defences, function(structure) {
        return structure.hits / structure.hitsMax;
    })
    
    function findEnergy() {
        console.log("Finding Energy");
        if(spawn.energy < (spawn.energyCapacity / 2)) {
            harvester(creep);
        }
        else if(spawn.transferEnergy(creep) == ERR_NOT_IN_RANGE) {
            creep.moveTo(spawn);
        }
    }
    
    // Decision Tree
    if(spawn.hits < spawn.hitsMax) {
        creep.moveTo(spawn);
        creep.repair(spawn);
    }
    // else if(construtionSites == "" || creep.build(construtionSites[0]) == ERR_INVALID_TARGET) {
    //     console.log("No Construction Sites");
    //     harvester(creep);
    // }
    else if(creep.build(construtionSites[0]) == ERR_NOT_IN_RANGE) {
        console.log("Building Sites");
        creep.moveTo(construtionSites[0]);
    } 
    else if(creep.build(construtionSites[0]) == ERR_NOT_ENOUGH_RESOURCES) {
        console.log("Not Enough Energy for Construction");
        findEnergy();
    }
    // For building up wall defences
    else if(defences != undefined) {
        console.log("reparing");
        var repairCode = creep.repair(defences[0]);
        if(repairCode == ERR_NOT_ENOUGH_RESOURCES) {
            creep.moveTo(defences[0]);
            creep.repair(defences[0]);
        } else {
            findEnergy();
        }
    }
 }