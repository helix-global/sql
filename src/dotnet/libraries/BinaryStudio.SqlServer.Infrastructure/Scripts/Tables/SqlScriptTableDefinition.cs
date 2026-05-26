using System;
using System.Collections.Generic;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [SqlScriptObject(typeof(SqlTableDefinition))]
    internal sealed class SqlScriptTableDefinition : SqlScriptCodeObject<SqlTableDefinition>,ISqlScriptTableDefinition
        {
        [UsedImplicitly][Field(EmptyIfNull = true)] public IList<ISqlScriptColumnDefinition> ColumnDefinitions { get; }
        [UsedImplicitly][Field(EmptyIfNull = true)] public IList<ISqlScriptConstraint> Constraints { get; }
        [UsedImplicitly][Field(EmptyIfNull = true)] public IList<SqlScriptTemporalPeriodDefinition> TemporalPeriodDefinitions { get; }

        #region ctor{IServiceProvider,SqlTableDefinition}
        public SqlScriptTableDefinition(IServiceProvider context,SqlTableDefinition source)
            : base(context,source)
            {
            return;
            }
        #endregion
        }
    }