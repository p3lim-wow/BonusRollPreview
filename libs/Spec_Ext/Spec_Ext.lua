local MAJOR, MINOR = 'Spec_Ext', 1
assert(LibStub, MAJOR .. ' requires LibStub')

local lib, oldMinor = LibStub:NewLibrary(MAJOR, MINOR)
if(not lib) then
  return
end

function lib:GetSpecialization(...)
  if C_SpecializationInfo and C_SpecializationInfo.GetSpecialization then
    return C_SpecializationInfo.GetSpecialization(...)
  elseif _G.GetSpecialization then
    return _G.GetSpecialization(...)
  end
end

function lib:GetSpecializationInfo(...)
  if C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo then
    return C_SpecializationInfo.GetSpecializationInfo(...)
  elseif _G.GetSpecializationInfo then
    return _G.GetSpecializationInfo(...)
  end
end