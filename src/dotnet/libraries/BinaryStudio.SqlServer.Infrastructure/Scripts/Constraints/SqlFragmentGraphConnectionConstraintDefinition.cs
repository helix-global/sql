using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(GraphConnectionConstraintDefinition))]
    internal sealed class SqlFragmentGraphConnectionConstraintDefinition : SqlFragmentConstraintDefinition<GraphConnectionConstraintDefinition>
        {
        public override SqlConstraintType Type { get{ return SqlConstraintType.Edge; }}

        #region ctor{IServiceProvider,GraphConnectionConstraintDefinition}
        public SqlFragmentGraphConnectionConstraintDefinition(IServiceProvider context,GraphConnectionConstraintDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }