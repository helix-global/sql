using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlProcedureDefinitionForCreate))]
    internal sealed class SqlScriptProcedureDefinitionForCreate : SqlScriptProcedureDefinition<SqlProcedureDefinitionForCreate>
        {
        [UsedImplicitly][Field] public Boolean IsOrAlterStatement { get; }

        #region ctor{IServiceProvider,SqlProcedureDefinitionForCreate}
        public SqlScriptProcedureDefinitionForCreate(IServiceProvider context,SqlProcedureDefinitionForCreate source)
            : base(context,source)
            {
            }
        #endregion
        }
    }