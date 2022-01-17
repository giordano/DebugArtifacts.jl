using DebugArtifacts
using Test

@testset "DebugArtifacts.jl" begin
    @test debug_artifact("OpenSpecFun") isa Nothing
end
