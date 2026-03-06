using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlClusterOption>))]
    public enum SqlClusterOption
        {
        Default,
        Clustered,
        NonClustered,
        NonClusteredHash,
        Hash,
        ClusteredColumnStore,
        NonClusteredColumnStore
        }
    }
