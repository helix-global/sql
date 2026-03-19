using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(NullableConstraintDefinition))]
    internal sealed class SqlFragmentNullableConstraintDefinition : SqlFragmentConstraintDefinition<NullableConstraintDefinition>
        {
        public override SqlConstraintType Type { get { return SqlConstraintType.Null; }}

        #region ctor{IServiceProvider,NullableConstraintDefinition}
        public SqlFragmentNullableConstraintDefinition(IServiceProvider context,NullableConstraintDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }