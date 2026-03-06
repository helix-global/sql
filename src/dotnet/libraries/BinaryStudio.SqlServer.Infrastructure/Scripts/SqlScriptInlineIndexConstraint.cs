using System;
using System.Collections.Generic;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlInlineIndexConstraint))]
    internal sealed class SqlScriptInlineIndexConstraint : SqlScriptConstraint<SqlInlineIndexConstraint>
        {
        [UsedImplicitly][Field] public IList<ISqlScriptIndexOption> Options { get; }

        #region ctor{IServiceProvider,SqlInlineIndexConstraint}
        public SqlScriptInlineIndexConstraint(IServiceProvider context,SqlInlineIndexConstraint source)
            : base(context,source)
            {
            }
        #endregion
        }
    }