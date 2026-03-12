using System;
using System.Collections.Generic;
using JetBrains.Annotations;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(DefaultConstraintDefinition))]
    internal class SqlFragmentDefaultConstraintDefinition : SqlFragmentConstraintDefinition<DefaultConstraintDefinition>
        {
        public override SqlConstraintType Type { get{ return SqlConstraintType.Default; }}

        #region ctor{IServiceProvider,DefaultConstraintDefinition}
        public SqlFragmentDefaultConstraintDefinition(IServiceProvider context,DefaultConstraintDefinition source)
            : base(context,source)
            {
            return;
            }
        #endregion
        }
    }