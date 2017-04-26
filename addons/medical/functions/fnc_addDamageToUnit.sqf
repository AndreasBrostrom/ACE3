/*
 * Author: PabstMirror
 * Manually Apply Damage to a unit (can cause lethal damage)
 * NOTE: because of caching, this will not have instant effects (~3 frame delay)
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 * 1: Damage to Add <NUMBER>
 * 2: Body part ("Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg") <STRING>
 * 3: Projectile Type <STRING>
 * 4: Source <OBJECT>
 *
 * Return Value:
 * Successful <BOOL>
 *
 * Example:
 * [player, 0.8, "rightleg", "bullet"] call ace_medical_fnc_addDamageToUnit
 * [cursorTarget, 1, "body", "stab", player] call ace_medical_fnc_addDamageToUnit
 *
 * Public: Yes
 */
// #define DEBUG_MODE_FULL
// #define DEBUG_TESTRESULTS
#include "script_component.hpp"

params [["_unit", objNull, [objNull]], ["_damageToAdd", -1, [0]], ["_bodyPart", "", [""]], ["_typeOfDamage", "", [""]], ["_instigator", objNull, [objNull]]];
TRACE_5("params",_unit,_damageToAdd,_bodyPart,_typeOfDamage,_instigator);

private _bodyPartIndex = ALL_BODY_PARTS find (toLower _bodyPart);
if (isNull _unit || {!local _unit} || {!alive _unit}) exitWith {ERROR_1("addDamageToUnit - badUnit %1", _this); false};
if (_damageToAdd < 0) exitWith {ERROR_1("addDamageToUnit - bad damage %1", _this); false};
if (_bodyPartIndex < 0) exitWith {ERROR_1("addDamageToUnit - bad selection %1", _this); false};

// Extension is case sensitive and expects this format (different from ALL_BODY_PARTS)
_bodyPart = ["Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg"] select _bodyPartIndex;

if (!isNull _instigator) then {
    _unit setVariable [QEGVAR(medical_engine,lastShooter), _instigator];
    _unit setVariable [QEGVAR(medical_engine,lastInstigator), _instigator];
};

#ifdef DEBUG_TESTRESULTS
private _startDmg = +(_unit getVariable [QGVAR(bodyPartDamage), [-1]]);
private _startPain = _unit getVariable [QGVAR(pain), 0];
#endif

[QEGVAR(medical_engine,woundReceived), [_unit, _bodyPart, _damageToAdd, _instigator, _typeOfDamage]] call CBA_fnc_localEvent;

#ifdef DEBUG_TESTRESULTS
private _endDmg = _unit getVariable [QGVAR(bodyPartDamage), [-1]];
private _endPain = _unit getVariable [QGVAR(pain), 0];
private _typeOfDamageAdj = _typeOfDamage call EFUNC(medical_damage,getTypeOfDamage);
private _config = configFile >> "ACE_Medical_Injuries" >> "damageTypes" >> _typeOfDamageAdj;
private _selectionSpecific = true;
if (isClass _config) then {
    _selectionSpecific = (getNumber (_config >> "selectionSpecific")) == 1;
} else {
    WARNING_2("Damage type not in config [%1:%2]", _typeOfDamage, _config);
};
INFO_4("Debug AddDamageToUnit: Type [%1] - Selection Specific [%2] - HitPoint [%3 -> %4]",_typeOfDamage,_selectionSpecific,_startDmg select _bodyPartIndex,_endDmg select _bodyPartIndex);
INFO_4("Pain Change [%1 -> %2] - BodyPartDamage Change [%3 -> %4]",_startPain,_endPain,_startDmg,_endDmg);
#endif

true
