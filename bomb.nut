::applyBombCarrierProperties <- function()
{
    activator.AddCond(130)
}

::resetBombOrigin <- function()
{
    bombFlag.SetAbsOrigin(bombSpawnOrigin)
}