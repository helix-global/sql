using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(UniqueConstraintDefinition))]
    internal class SqlScriptDomUniqueConstraintDefinition : SqlScriptDomConstraintDefinition<UniqueConstraintDefinition>,ISqlScriptUniqueConstraint
        {
        public SqlClusterOption ClusterOption { get; } = SqlClusterOption.Default;
        [UsedImplicitly][Field] public Boolean IsPrimaryKey { get; }

        #region ctor{IServiceProvider,UniqueConstraintDefinition}
        public SqlScriptDomUniqueConstraintDefinition(IServiceProvider context,UniqueConstraintDefinition source)
            : base(context,source)
            {
            var IndexType = source.IndexType;
            if (IndexType.IndexTypeKind != null) {
                switch (IndexType.IndexTypeKind.Value) {
                    case IndexTypeKind.Clustered:               { ClusterOption = SqlClusterOption.Clustered;               } break;
                    case IndexTypeKind.NonClustered:            { ClusterOption = SqlClusterOption.NonClustered;            } break;
                    case IndexTypeKind.NonClusteredHash:        { ClusterOption = SqlClusterOption.NonClusteredHash;        } break;
                    case IndexTypeKind.ClusteredColumnStore:    { ClusterOption = SqlClusterOption.ClusteredColumnStore;    } break;
                    case IndexTypeKind.NonClusteredColumnStore: { ClusterOption = SqlClusterOption.NonClusteredColumnStore; } break;
                    default: throw new ArgumentOutOfRangeException();
                    }
                }
            return;
            }
        #endregion
        }
    }