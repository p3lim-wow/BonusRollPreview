local addonName, addon = ...

function addon:GetSpecialization(...)
  if C_SpecializationInfo and C_SpecializationInfo.GetSpecialization then
    return C_SpecializationInfo.GetSpecialization(...)
  elseif _G.GetSpecialization then
    return _G.GetSpecialization(...)
  end
end

function addon:GetSpecializationInfo(...)
  if C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo then
    return C_SpecializationInfo.GetSpecializationInfo(...)
  elseif _G.GetSpecializationInfo then
    return _G.GetSpecializationInfo(...)
  end
end