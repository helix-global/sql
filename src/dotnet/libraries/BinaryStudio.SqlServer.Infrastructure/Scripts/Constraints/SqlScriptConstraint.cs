using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptConstraint<T> : SqlScriptCodeObject<T>,ISqlScriptConstraint
        where T : SqlConstraint
        {
        [UsedImplicitly][Field] public SqlIdentifier Name { get; }
        [UsedImplicitly][Field] public SqlConstraintType Type { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptConstraint(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        public override String ToString()
            {
            return (Name != null)
                ? Name.ToString()
                : Type.ToString();
            }
        #endregion
        }
    }