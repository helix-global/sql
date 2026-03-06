namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal interface ISqlScriptUniqueConstraint
        {
        SqlClusterOption ClusterOption { get; }
        }
    }