using System;
using System.Collections.Generic;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlTableDefinition))]
    internal sealed class SqlScriptTableDefinition : SqlScriptCodeObject<SqlTableDefinition>
        {
        [SqlModelFieldMapping(EmptyIfNull = true)][UsedImplicitly] public IList<SqlScriptColumnDefinition> ColumnDefinitions { get; }
        [SqlModelFieldMapping(EmptyIfNull = true)][UsedImplicitly] public IList<ISqlScriptConstraint> Constraints { get; }
        [SqlModelFieldMapping(EmptyIfNull = true)][UsedImplicitly] public IList<SqlScriptTemporalPeriodDefinition> TemporalPeriodDefinitions { get; }

        #region ctor{IServiceProvider,SqlTableDefinition}
        public SqlScriptTableDefinition(IServiceProvider context,SqlTableDefinition source)
            : base(context,source)
            {
            return;
            }
        #endregion
        }
    }